# Generated by Django 5.1.5 on 2025-01-23 22:05

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('accounts', '0002_userprofile_delete_order'),
    ]

    operations = [
        migrations.AddField(
            model_name='userprofile',
            name='key_skills',
            field=models.TextField(blank=True, null=True),
        ),
    ]
