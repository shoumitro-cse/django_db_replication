from django.db import models


class BaseModel(models.Model):
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        abstract = True
        
    def save(self, *args, **kwargs):
    	#for db in ["replica0", "replica1", "replica2"]:
    	#	kwargs.update({"using": db})
    	#	super().save(*args, **kwargs)
    	#kwargs.update({"using": "default"})
    	return super().save(*args, **kwargs)

    def delete(self, *args, **kwargs):
    	#for db in ["replica0", "replica1", "replica2"]:
    	#	kwargs.update({"using": db})
    	#	super().save(*args, **kwargs)
    	#kwargs.update({"using": "default"})
    	return super().delete(*args, **kwargs)
