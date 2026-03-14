from django.db import models


class PhotoEntry(models.Model):
    id = models.AutoField(primary_key=True)
    image = models.ImageField(upload_to='photos/')
    latitude = models.FloatField()
    longitude = models.FloatField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self) -> str:
        return f'PhotoEntry {self.pk} ({self.latitude}, {self.longitude})'
