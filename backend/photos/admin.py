from django.contrib import admin

from .models import PhotoEntry


@admin.register(PhotoEntry)
class PhotoEntryAdmin(admin.ModelAdmin):
    list_display = ('id', 'latitude', 'longitude', 'created_at')
    list_filter = ('created_at',)
    search_fields = ('id',)
    readonly_fields = ('created_at',)
