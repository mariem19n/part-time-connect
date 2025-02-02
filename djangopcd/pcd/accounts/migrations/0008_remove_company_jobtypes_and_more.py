# Generated by Django 5.1.5 on 2025-01-31 17:08

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('accounts', '0007_jobtype_company_jobtypes'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='company',
            name='jobTypes',
        ),
        migrations.RemoveField(
            model_name='company',
            name='workplace_images',
        ),
        migrations.AddField(
            model_name='company',
            name='job_types',
            field=models.JSONField(default=list),
        ),
        migrations.DeleteModel(
            name='JobType',
        ),
        migrations.DeleteModel(
            name='WorkplaceImage',
        ),
        migrations.AddField(
            model_name='company',
            name='workplace_images',
            field=models.JSONField(default=list),
        ),
    ]
