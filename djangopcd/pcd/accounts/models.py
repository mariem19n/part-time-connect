from django.db import models

# Create your models here.
# accounts/models.py
from django.db import models

class Order(models.Model):
    # Define fields for the Order model
    product_name = models.CharField(max_length=100)
    quantity = models.IntegerField()
    # Add other fields as needed
