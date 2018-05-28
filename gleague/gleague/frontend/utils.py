from flask import request


def get_templates_root_folder():
    return (
        'redesign/' if request.cookies.get('design', 'new') != 'old' else ''
    )
