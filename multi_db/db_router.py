# https://docs.djangoproject.com/en/4.1/topics/db/multi-db/
import random


class PrimaryReplicaRouter:
    def db_for_read(self, model, **hints):
        """
        Reads go to a randomly-chosen replica.
        """
        return random.choice(['replica0', 'replica1', 'replica2'])

    def db_for_write(self, model, **hints):
        """
        Writes always go to primary(default).
        """
        return 'default'

    def allow_relation(self, obj1, obj2, **hints):
        """
        Relations between objects are allowed if both objects are
        in the primary/replica pool.
        """
        db_set = {'default', 'replica0', 'replica1', 'replica2'}
        if obj1._state.db in db_set and obj2._state.db in db_set:
            return True
        return None

    def allow_migrate(self, db, app_label, model_name=None, **hints):
        """
        All non-auth models end up in this pool.
        """
        return True
        
        
class AuthRouter:
    """
    A router to control all database operations on models in the
    auth and contenttypes applications.
    """
    route_app_labels = {'auth', 'contenttypes'}

    def db_for_read(self, model, **hints):
        """
        Attempts to read auth and contenttypes models go to auth_db.
        """
        if model._meta.app_label in self.route_app_labels:
            return 'auth_db'
        return None

    def db_for_write(self, model, **hints):
        """
        Attempts to write auth and contenttypes models go to auth_db.
        """
        if model._meta.app_label in self.route_app_labels:
            return 'auth_db'
        return None

    def allow_relation(self, obj1, obj2, **hints):
        """
        Allow relations if a model in the auth or contenttypes apps is
        involved.
        """
        if (
            obj1._meta.app_label in self.route_app_labels or
            obj2._meta.app_label in self.route_app_labels
        ):
           return True
        return None

    def allow_migrate(self, db, app_label, model_name=None, **hints):
        """
        Make sure the auth and contenttypes apps only appear in the
        'auth_db' database.
        """
        if app_label in self.route_app_labels:
            return db == 'auth_db'
        return None
        

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        #'NAME': BASE_DIR / 'primary_db.sqlite3',
    },
    #'auth_db': {
    #    'ENGINE': 'django.db.backends.sqlite3',
    #    'NAME': BASE_DIR / 'auth_db.sqlite3',
    #},
    'replica0': {
        'ENGINE': 'django.db.backends.sqlite3',
        #'NAME': BASE_DIR / 'replica0_db.sqlite3',
    },
    'replica1': {
        'ENGINE': 'django.db.backends.sqlite3',
        #'NAME': BASE_DIR / 'replica1_db.sqlite3',
    },
    'replica2': {
        'ENGINE': 'django.db.backends.sqlite3',
        #'NAME': BASE_DIR / 'replica2_db.sqlite3',
    },
}

   
# https://stackoverflow.com/questions/53859629/how-to-add-database-routers-to-a-django-project 
class DiscourseRouter:
    """
    A router to control all database operations on models in the
    discourse application.
    """
    def db_for_read(self, model, **hints):
        """
        Attempts to read discourse models go to discourse.
        """
        if model._meta.app_label == 'discourse':
            return 'discourse'
        return None

    def db_for_write(self, model, **hints):
        """
        Attempts to write discourse models go to discourse.
        """
        if model._meta.app_label == 'discourse':
            return 'discourse'
        return None

    def allow_relation(self, obj1, obj2, **hints):
        """
        Allow relations if a model in the discourse app is involved.
        """
        if obj1._meta.app_label == 'discourse' or \
           obj2._meta.app_label == 'discourse':
           return True
        return None

    def allow_migrate(self, db, app_label, model_name=None, **hints):
        """
        Make sure the discourse app only appears in the 'discourse'
        database.
        """
        if app_label == 'discourse':
            return db == 'discourse'
        return None
        
        
class ExampleDatabaseRouter(object):
    """
    Determine how to route database calls for an app's models (in this case, for an app named Example).
    All other models will be routed to the next router in the DATABASE_ROUTERS setting if applicable,
    or otherwise to the default database.
    """

    def db_for_read(self, model, **hints):
        """Send all read operations on Example app models to `example_db`."""
        if model._meta.app_label == 'example':
            return 'example_db'
        return None

    def db_for_write(self, model, **hints):
        """Send all write operations on Example app models to `example_db`."""
        if model._meta.app_label == 'example':
            return 'example_db'
        return None

    def allow_relation(self, obj1, obj2, **hints):
        """Determine if relationship is allowed between two objects."""

        # Allow any relation between two models that are both in the Example app.
        if obj1._meta.app_label == 'example' and obj2._meta.app_label == 'example':
            return True
        # No opinion if neither object is in the Example app (defer to default or other routers).
        elif 'example' not in [obj1._meta.app_label, obj2._meta.app_label]:
            return None

        # Block relationship if one object is in the Example app and the other isn't.
            return False

    def allow_migrate(self, db, app_label, model_name=None, **hints):
        """Ensure that the Example app's models get created on the right database."""
        if app_label == 'example':
            # The Example app should be migrated only on the example_db database.
            return db == 'example_db'
        elif db == 'example_db':
            # Ensure that all other apps don't get migrated on the example_db database.
            return False

        # No opinion for all other scenarios
        return None
