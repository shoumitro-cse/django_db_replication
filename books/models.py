from django.db import connection, connections
from django.db import models
from core.models import BaseModel


class Book(BaseModel):
    name = models.CharField(max_length=32, default="")
    author_name = models.CharField(max_length=32, default="")

    class Meta:
        db_table = "book"

    def __str__(self):
        return str(self.name)

    def save(self, *args, **kwargs):
        """Preventing data modification."""
        return super().save(*args, **kwargs)

    def delete(self, *args, **kwargs):
        """Preventing data deletion."""
        return super().delete(*args, **kwargs)
