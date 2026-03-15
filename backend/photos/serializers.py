from rest_framework import serializers

from .models import PhotoEntry


class PhotoEntrySerializer(serializers.ModelSerializer):
    class Meta:
        model = PhotoEntry
        fields = [
            'id',
            'image',
            'latitude',
            'longitude',
            'location_name',
            'note',
            'category',
            'extracted_text',
            'extracted_data',
            'processing_status',
            'processing_error',
            'processed_at',
            'created_at',
        ]
        read_only_fields = [
            'id',
            'extracted_text',
            'extracted_data',
            'processing_status',
            'processing_error',
            'processed_at',
            'created_at',
        ]
