from django.contrib import admin

from .models import PhotoEntry


@admin.register(PhotoEntry)
class PhotoEntryAdmin(admin.ModelAdmin):
    list_display = (
        'id',
        'category',
        'latitude',
        'longitude',
        'processing_status',
        'created_at',
    )
    list_filter = ('category', 'processing_status', 'created_at')
    search_fields = ('id', 'category', 'location_name')
    readonly_fields = ('created_at', 'processed_at')
