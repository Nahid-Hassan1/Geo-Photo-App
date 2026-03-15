from django.db import models


class ProcessingStatus(models.TextChoices):
    PENDING = 'pending', 'Pending'
    PROCESSED = 'processed', 'Processed'
    FAILED = 'failed', 'Failed'


class PhotoEntry(models.Model):
    id = models.AutoField(primary_key=True)
    image = models.ImageField(upload_to='photos/')
    latitude = models.FloatField()
    longitude = models.FloatField()
    location_name = models.CharField(max_length=255, blank=True, null=True)
    note = models.TextField(blank=True, null=True)
    category = models.CharField(max_length=100, default='uncategorized')
    extracted_text = models.TextField(blank=True, null=True)
    extracted_data = models.JSONField(blank=True, null=True)
    processing_status = models.CharField(
        max_length=20,
        choices=ProcessingStatus.choices,
        default=ProcessingStatus.PENDING,
    )
    processing_error = models.TextField(blank=True, null=True)
    processed_at = models.DateTimeField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self) -> str:
        return f'PhotoEntry {self.pk} ({self.category})'
