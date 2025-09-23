from django import template

register = template.Library()

@register.filter
def replace(value, arg):
    """Replace parts of a string"""
    if '|' in arg:
        old, new = arg.split('|', 1)
        return value.replace(old, new)
    return value

@register.filter
def format_setting_name(value):
    """Format setting key as a readable name"""
    return value.replace('_', ' ').title()

@register.filter
def div(value, arg):
    """Divide value by arg"""
    try:
        return float(value) / float(arg)
    except (ValueError, ZeroDivisionError, TypeError):
        return 0

@register.filter
def mul(value, arg):
    """Multiply value by arg"""
    try:
        return float(value) * float(arg)
    except (ValueError, TypeError):
        return 0

@register.filter
def percentage(value, total):
    """Calculate percentage"""
    try:
        if total == 0:
            return 0
        return (float(value) / float(total)) * 100
    except (ValueError, TypeError, ZeroDivisionError):
        return 0