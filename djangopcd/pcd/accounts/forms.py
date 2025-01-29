from django.forms import ModelForm
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth.models import User
from django import forms

class OrderForm(ModelForm):
    class Meta:
        model = User
        fields = '__all__'


class CreateUserForm(UserCreationForm):
    username = forms.CharField(max_length=200, required=True)
    email = forms.EmailField(required=True)
    resume = forms.FileField(required=False)
    skills = forms.CharField(max_length=200, required=False)

    class Meta:
        model = User
        fields = ('username', 'email', 'password', 'resume', 'skills')

    def save(self, commit=True):
        user = super().save(commit=False)
        user.email = self.cleaned_data['email']
        user.username = self.cleaned_data['username']
        if commit:
            user.save()
        return user

# from django.contrib.auth.forms import UserChangeForm

# class CustomUserChangeForm(UserChangeForm):
#     class Meta:
#         model = User
#         fields = ['username', 'email']

# from django import forms
# from django.contrib.auth.models import User

# class CustomUserForm(forms.ModelForm):
#     class Meta:
#         model = User
#         fields = ['username']  # Only include the username field

# class ResetPasswordForm(forms.Form):
#     reset_password = forms.CharField(
#         widget=forms.PasswordInput,
#         label="New Password"
#     )



from django import forms
from .models import Company

class CompanyRegistrationForm(forms.ModelForm):
    class Meta:
        model = Company
        fields = ['company_name', 'email', 'password', 'workplace_images']
        widgets = {
            'password': forms.PasswordInput(),
        }

