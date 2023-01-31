from django.db import connection, connections
from django.db import models
from core.models import BaseModel


class Customer(BaseModel):
    name = models.CharField(max_length=32, default="")
    addr = models.CharField(max_length=32, default="")

    class Meta:
        db_table = "customer"

    def __str__(self):
        return str(self.name)

    def save(self, *args, **kwargs):
        """Preventing data modification."""
        return super().save(*args, **kwargs)

    def delete(self, *args, **kwargs):
        """Preventing data deletion."""
        return super().delete(*args, **kwargs)
