# Generated by Django 5.1.4 on 2025-02-01 22:21

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('accounts', '0005_rename_resume_files_userregistration_resume'),
    ]

    operations = [
        migrations.CreateModel(
            name='CompanyRegistration',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('username', models.CharField(max_length=100)),
                ('email', models.EmailField(max_length=254, unique=True)),
                ('password', models.CharField(max_length=128)),
                ('photo', models.ImageField(blank=True, default=None, null=True, upload_to='photos/')),
                ('jobtype', models.CharField(max_length=200)),
                ('company_description', models.TextField(blank=True, null=True)),
            ],
        ),
    ]
