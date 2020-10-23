// Original source for GUI programmer can be found
// here https://www.robot-electronics.co.uk/files/iceWerx.pdf

using System;
using System.IO;
using System.IO.Ports;
using System.CommandLine;
using System.CommandLine.Invocation;

class Program
{
    enum cmds
    {
        DONE = 0xB0, GET_VER, RESET_FPGA, ERASE_CHIP, ERASE_64k, PROG_PAGE, READ_PAGE, VERIFY_PAGE, GET_CDONE, RELEASE_FPGA
    };

    const Int32 PROGSIZE = 1048576;
    static byte[] sbuf = new byte[300];

    static void Main(string[] args)
    {
        var info = new IceSerialInfo();
        var argport = new Option<string>(
            aliases: new string[] { "--port", "-p" },
            description: "Set device name (can be null)",
            getDefaultValue: () =>
            {
                return null;
            });
        var argfile = new Argument<FileInfo>(
            name: "file",
            description: "Binary bitstream file to upload",
            getDefaultValue: () => null);
        var argverify = new Option<bool>(
            aliases: new string[] { "--verify", "-v" },
            description: "Verify after upload");
        var cmdlist = new Command("list", "Enumerate serial port devices");
        var cmdrun = new Command("run", "Run the FPGA device");
        cmdrun.AddOption(argport);
        var cmdreset = new Command("reset", "Reset (not erase) the FPGA device");
        cmdreset.AddOption(argport);
        var cmdprogram = new Command("program", "Upload binary bitstream to the FPGA");
        cmdprogram.AddOption(argport);
        cmdprogram.AddOption(argverify);
        cmdprogram.AddArgument(argfile);
        var root = new RootCommand { cmdlist, cmdreset, cmdprogram };
        cmdlist.Handler = CommandHandler.Create<string, FileInfo>(
            (port, file) =>
            {
                info.enumerate();
            });
        cmdrun.Handler = CommandHandler.Create<string>(
            (port) =>
            {
                var device = tryGetDevice(port == null ? info.tryFindDevicePort() : port);
                runFpga(device);
                Console.WriteLine("Running...");
            });
        cmdreset.Handler = CommandHandler.Create<string>(
            (port) =>
            {
                var device = tryGetDevice(port == null ? info.tryFindDevicePort() : port);
                resetFpga(device);
                Console.WriteLine("Done.");
            });
        cmdprogram.Handler = CommandHandler.Create<bool, string, FileInfo>(
            (verify, port, file) =>
            {
                var device = tryGetDevice(port == null ? info.tryFindDevicePort() : port);
                doUpload(device, file, verify);
            });
        root.Invoke(args);
        Environment.Exit(0);
    }

    static SerialPort tryGetDevice(string foundPort)
    {
        if (foundPort == null)
        {
            Console.WriteLine($"Error: IceWerx device not found.");
            Environment.Exit(1);
        }
        SerialPort device = new SerialPort(
            portName: foundPort,
            parity: 0,
            baudRate: 19200,
            stopBits: StopBits.Two,
            dataBits: 8
        );
        device.ReadTimeout = 5000;
        device.WriteTimeout = 5000;

        try
        {
            device.Open();
        }
        catch (Exception e)
        {   // Hide some errors.
            Console.WriteLine($"USB device failed to open: {e.Message}");
            Environment.Exit(1);
        }

        sbuf[0] = (byte)cmds.GET_VER;
        transmit(device, 1);
        recieve(device, 2);
        if (sbuf[0] == 38) Console.WriteLine("Device Info: iceFUN Programmer, V{0}", sbuf[1]);
        return device;
    }

    static void transmit(SerialPort dev, int write_bytes)
    {
        try
        {
            dev.Write(sbuf, 0, write_bytes);      // writes specified amount of sbuf out on COM port
        }
        catch (Exception)
        {

        }
    }

    static void recieve(SerialPort dev, int read_bytes)
    {
        int x;
        for (x = 0; x < read_bytes; x++)    // this will call the read function for the passed number times, 
        {                                   // this way it ensures each byte has been correctly recieved while
            try                             // still using timeouts
            {
                dev.Read(sbuf, x, 1);     // retrieves 1 byte at a time and places in sbuf at position x
            }
            catch (Exception)               // timeout or other error occured, set lost comms indicator
            {
                sbuf[0] = 255;
            }
        }
    }

    static void resetFpga(SerialPort device)
    {
        sbuf[0] = (byte)cmds.RESET_FPGA;
        transmit(device, 1);
        recieve(device, 3);
        Console.WriteLine("FPGA reset.");
        Console.WriteLine("Flash ID = {0:X02} {1:X02} {2:X02}", sbuf[0], sbuf[1], sbuf[2]);
    }

    static void runFpga(SerialPort device)
    {
        sbuf[0] = (byte)cmds.RELEASE_FPGA;
        transmit(device, 1);
        recieve(device, 1);
    }

    // Verify the file already loaded in pbuf
    static bool doVerify(SerialPort device, byte[] pbuf, int len)
    {
        int addr = 0;
        Console.Write("Verifying ");
        int cnt = 0;
        while (addr < len)
        {
            sbuf[0] = (byte)cmds.VERIFY_PAGE;
            sbuf[1] = (byte)(addr >> 16);
            sbuf[2] = (byte)(addr >> 8);
            sbuf[3] = (byte)addr;
            for (int x = 0; x < 256; x++) sbuf[x + 4] = pbuf[addr++];
            transmit(device, 260);
            recieve(device, 4);
            if (sbuf[0] > 0)
            {
                Console.WriteLine();
                Console.WriteLine("Verify failed at {0:X06}, {1:X02} expected, {2:X02} read.", addr - 256 + sbuf[1] - 4, sbuf[2], sbuf[3]);
                return false;
            }
            if (++cnt == 10)
            {
                cnt = 0;
                Console.Write(".");
            }
        }
        Console.WriteLine();
        Console.WriteLine("Verify Success!");
        return true;
    }

    static void doUpload(SerialPort device, FileInfo file, bool verify)
    {
        if (file == null || !file.Exists)
        {
            Console.WriteLine($"Error: File \"{file.FullName}\" does not exist");
            Environment.Exit(1);
        }

        byte[] pbuf = new byte[PROGSIZE];
        FileStream fs = file.OpenRead();
        for (int i = 0; i < PROGSIZE; i++) pbuf[i] = 0xff;
        resetFpga(device);
        int len = (int)fs.Length;
        Console.WriteLine("Program length 0x{0:X06}", len);
        fs.Read(pbuf, 0, len);
        int erasePages = (len >> 16) + 1;
        for (int page = 0; page < erasePages; page++)
        {
            sbuf[0] = (byte)cmds.ERASE_64k;
            sbuf[1] = (byte)page;
            transmit(device, 2);
            Console.WriteLine("Erasing sector 0x{0:X02}0000", page);
            recieve(device, 1);
        }
        int addr = 0;
        Console.Write("Programming ");
        int cnt = 0;
        while (addr < len)
        {
            sbuf[0] = (byte)cmds.PROG_PAGE;
            sbuf[1] = (byte)(addr >> 16);
            sbuf[2] = (byte)(addr >> 8);
            sbuf[3] = (byte)addr;
            for (int x = 0; x < 256; x++) sbuf[x + 4] = pbuf[addr++];
            transmit(device, 260);
            recieve(device, 4);
            if (sbuf[0] != 0)
            {
                Console.WriteLine();
                Console.WriteLine("Program failed at {0:X06}, {1:X02} expected, {2:X02} read.", addr - 256 + sbuf[1] - 4, sbuf[2], sbuf[3]);
                fs.Close();
                Environment.Exit(1);
            }
            if (++cnt == 10)
            {
                cnt = 0;
                Console.Write(".");
            }
        }
        if (sbuf[0] == 0)
        {
            if (verify)
            {
                doVerify(device, pbuf, len);
            }
            runFpga(device);
            Console.WriteLine("Done.");
        }
        fs.Close();
    }
}
