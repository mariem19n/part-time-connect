from django.db import models
from accounts.models import UserRegistration, CompanyRegistration

class Message(models.Model):
    MESSAGE_TYPES = (
        ('text', 'Text'),
        ('image', 'Image'),
        ('file', 'File'),
        ('application', 'Job Application'),
        ('profile_view', 'Profile View Notification')
    )
    STATUS_CHOICES = (
        ('unread', 'Unread'),
        ('read', 'Read'),
        ('delivered', 'Delivered')
    )

    sender_user = models.ForeignKey(UserRegistration, related_name='sent_messages', on_delete=models.CASCADE, null=True, blank=True)
    sender_company = models.ForeignKey(CompanyRegistration, related_name='sent_messages', on_delete=models.CASCADE, null=True, blank=True)
    receiver_user = models.ForeignKey(UserRegistration, related_name='received_messages', on_delete=models.CASCADE, null=True, blank=True)
    receiver_company = models.ForeignKey(CompanyRegistration, related_name='received_messages', on_delete=models.CASCADE, null=True, blank=True)
    content = models.TextField()
    timestamp = models.DateTimeField(auto_now_add=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='unread')
    message_type = models.CharField(max_length=50, choices=MESSAGE_TYPES, default='text')
    attachment = models.FileField(upload_to='attachments/', null=True, blank=True)
    deleted = models.BooleanField(default=False)
    related_job = models.ForeignKey('jobs.Job', null=True, blank=True, on_delete=models.SET_NULL)  # For job applications

    class Meta:
        ordering = ['-timestamp']
        indexes = [
            models.Index(fields=['sender_user', 'receiver_user']),
            models.Index(fields=['sender_company', 'receiver_user']),
            models.Index(fields=['timestamp']),
        ]

    def clean(self):
        # Validation logic
        if not (self.sender_user or self.sender_company):
            raise ValidationError('A sender (user or company) must be specified.')
        if not (self.receiver_user or self.receiver_company):
            raise ValidationError('A receiver (user or company) must be specified.')
        if self.sender_user and self.sender_company:
            raise ValidationError('Message cannot have both user and company sender.')
        if self.receiver_user and self.receiver_company:
            raise ValidationError('Message cannot have both user and company receiver.')

    def save(self, *args, **kwargs):
        self.full_clean()  # Runs clean() validation
        super().save(*args, **kwargs)

    def __str__(self):
        sender = self.sender_user if self.sender_user else self.sender_company
        receiver = self.receiver_user if self.receiver_user else self.receiver_company
        return f"{self.message_type} message from {sender} to {receiver} at {self.timestamp}"
##################

class Notification(models.Model):
    TYPES = [
        ('message', 'Message'),
        ('application', 'Job Application'),
        ('profile_view', 'Profile View')
    ]
    
    recipient_id = models.IntegerField()  # Stores user/company ID
    recipient_type = models.CharField(max_length=10)  # 'user' or 'company'
    sender_id = models.IntegerField()
    sender_type = models.CharField(max_length=10)
    notification_type = models.CharField(max_length=20, choices=TYPES)
    message = models.TextField()
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    related_id = models.IntegerField(null=True)

    class Meta:
        indexes = [
            models.Index(fields=['recipient_id', 'recipient_type']),
            models.Index(fields=['is_read']),
        ]

    def __str__(self):
        return f"{self.notification_type} for {self.recipient_type}_{self.recipient_id}"

    def clean(self):
        """Validate sender/recipient exists"""
        from accounts.models import UserRegistration, CompanyRegistration
        
        # Validate recipient
        if self.recipient_type == 'user':
            if not UserRegistration.objects.filter(id=self.recipient_id).exists():
                raise ValidationError("Recipient user not found")
        elif self.recipient_type == 'company':
            if not CompanyRegistration.objects.filter(id=self.recipient_id).exists():
                raise ValidationError("Recipient company not found")
        else:
            raise ValidationError("Invalid recipient_type")

        # Validate sender (optional but recommended)
        if self.sender_type == 'user':
            if not UserRegistration.objects.filter(id=self.sender_id).exists():
                raise ValidationError("Sender user not found")
        elif self.sender_type == 'company':
            if not CompanyRegistration.objects.filter(id=self.sender_id).exists():
                raise ValidationError("Sender company not found")
        else:
            raise ValidationError("Invalid sender_type")

