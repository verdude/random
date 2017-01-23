from django.shortcuts import render

from django.http import HttpResponse

def index(request):
    return HttpResponse("Hello, dis the main page for the polls.")

