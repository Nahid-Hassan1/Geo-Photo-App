from rest_framework import status
from rest_framework.parsers import FormParser, MultiPartParser
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import ProcessingStatus
from .serializers import PhotoEntrySerializer
from .services.extraction_service import extract_metadata


class PhotoUploadView(APIView):
    parser_classes = [MultiPartParser, FormParser]

    def post(self, request, *args, **kwargs):
        serializer = PhotoEntrySerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        photo = serializer.save()

        extraction = extract_metadata(photo.image.path, photo.category)
        status_value = extraction.get('status')

        if status_value == 'processed':
            photo.extracted_text = extraction.get('text')
            photo.extracted_data = extraction.get('data')
            photo.processing_status = ProcessingStatus.PROCESSED
            photo.processing_error = None
            photo.processed_at = extraction.get('processed_at')
            photo.save(
                update_fields=[
                    'extracted_text',
                    'extracted_data',
                    'processing_status',
                    'processing_error',
                    'processed_at',
                ]
            )
        elif status_value == 'failed':
            photo.processing_status = ProcessingStatus.FAILED
            photo.processing_error = extraction.get('error')
            photo.processed_at = extraction.get('processed_at')
            photo.save(
                update_fields=[
                    'processing_status',
                    'processing_error',
                    'processed_at',
                ]
            )
        elif status_value == 'skipped':
            photo.processing_status = ProcessingStatus.PENDING
            photo.processing_error = extraction.get('error')
            photo.save(update_fields=['processing_status', 'processing_error'])

        return Response(
            {
                'status': 'success',
                'message': 'Photo stored successfully',
                'processing_status': photo.processing_status,
            },
            status=status.HTTP_201_CREATED,
        )
