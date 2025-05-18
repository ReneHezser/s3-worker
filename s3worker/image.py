import logging
from pathlib import Path
from pdf2image import convert_from_path

from s3worker import constants as const


logger = logging.getLogger(__name__)

def file_name_generator(size):
    yield str(size)


def generate_preview(
    pdf_path: Path,
    output_folder: Path,
    size,
    page_number: int = 1,
):
    """Generate jpg thumbnail/preview images of PDF document"""
    logger.debug(
        f"pdf_path={pdf_path},"
        f"output_folder={output_folder},"
        f"size={size},"
        f"page_number={page_number},"
    )
    kwargs = {
        'pdf_path': str(pdf_path),
        'output_folder': str(output_folder),
        'fmt': 'jpg',
        'first_page': page_number,
        'last_page': page_number,
        'single_file': True,
        'size': (size, None),
        'output_file': file_name_generator(size)
    }
    output_folder.mkdir(exist_ok=True, parents=True)

    # generates jpeg previews of PDF file using pdftoppm (poppler-utils)
    convert_from_path(**kwargs)
