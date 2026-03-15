import os
from datetime import datetime


def extract_metadata(image_path: str, category: str):
    mode = os.getenv('IMAGE_EXTRACTION_MODE', 'none').lower()

    if mode == 'none':
        return {
            'status': 'skipped',
            'text': None,
            'data': None,
            'error': 'Image extraction not configured.',
            'processed_at': None,
        }

    if mode == 'mock':
        return {
            'status': 'processed',
            'text': 'Sample extracted text for demo purposes.',
            'data': {
                'category': category,
                'items': [
                    {
                        'name': 'Sample Item',
                        'brand': 'Sample Brand',
                        'price': '10.00',
                        'quantity': '1',
                        'description': 'Mock extracted data.',
                    }
                ],
            },
            'error': None,
            'processed_at': datetime.utcnow(),
        }

    return {
        'status': 'failed',
        'text': None,
        'data': None,
        'error': f'Unsupported IMAGE_EXTRACTION_MODE: {mode}',
        'processed_at': datetime.utcnow(),
    }
