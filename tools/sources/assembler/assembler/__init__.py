from importlib import metadata

__version__ = metadata.version(__name__)
__all__ = ["assemble", "assemble_file"]

from .assembler import assemble, assemble_file
