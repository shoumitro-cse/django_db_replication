python manage.py migrate --database default
python manage.py migrate --database replica0
python manage.py migrate --database replica1
python manage.py migrate --database replica2


User.objects.db_manager('new_users').create_user(...)



class MyManager(models.Manager):
    def get_queryset(self):
        qs = CustomQuerySet(self.model)
        if self._db is not None:
            qs = qs.using(self._db)
        return qs
        
        
        
from django.db import connections
with connections['my_db_alias'].cursor() as cursor:
    ...
