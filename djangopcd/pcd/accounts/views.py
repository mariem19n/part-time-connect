from django.shortcuts import render, redirect
from django.contrib.auth.forms import UserCreationForm
from .forms import CreateUserForm
from django.contrib.auth import authenticate , login, logout
from django.contrib import messages
from django.contrib.auth.decorators import login_required


login_required(login_url='login')
def registerPage(request):
    form = CreateUserForm()
    if request.method == 'POST':
        form = CreateUserForm(request.POST)  # Corrected variable name
        if form.is_valid():  # Proper indentation
            form.save()  # Save the user data
            return redirect('login')  # Redirect to the login page after successful registration
    
    context = {'form': form}
    return render(request, 'accounts/register.html', context)

login_required(login_url='login')
def loginPage(request):
    context = {}  
    if request.method == 'POST':
        username = request.POST.get('username')
        password = request.POST.get('password')

        user = authenticate(request, username=username, password=password)
        if user is not None:
            login(request, user)
            return redirect('home')
        else:
            messages.info(request, 'Username OR password is incorrect')
            return render(request, 'accounts/login.html', context)
    return render(request, 'accounts/login.html', context)


login_required(login_url='login')
def logoutUser(request) :
    logout(request)
    return redirect('login')
