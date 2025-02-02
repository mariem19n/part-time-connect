# Generated by Django 5.1.5 on 2025-01-31 17:32

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('accounts', '0008_remove_company_jobtypes_and_more'),
    ]

    operations = [
        migrations.CreateModel(
            name='JobType',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(blank=True, max_length=100)),
            ],
        ),
        migrations.CreateModel(
            name='WorkplaceImage',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('image', models.ImageField(upload_to='workplace_images/')),
                ('uploaded_at', models.DateTimeField(auto_now_add=True)),
            ],
        ),
        migrations.RemoveField(
            model_name='company',
            name='job_types',
        ),
        migrations.RemoveField(
            model_name='company',
            name='workplace_images',
        ),
        migrations.AddField(
            model_name='company',
            name='jobTypes',
            field=models.ManyToManyField(to='accounts.jobtype'),
        ),
        migrations.AddField(
            model_name='company',
            name='workplace_images',
            field=models.ManyToManyField(blank=True, to='accounts.workplaceimage'),
        ),
    ]
