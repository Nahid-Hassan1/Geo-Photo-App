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
            'created_at',
        ]
        read_only_fields = ['id', 'created_at']
