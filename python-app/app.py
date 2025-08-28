import random
from flask import Flask, request, session, render_template_string

app = Flask(__name__)
app.secret_key = 'super_secret_key'  # Change this to a secure random value in production

@app.route('/', methods=['GET', 'POST'])
def guess():
    # Initialize game if not started
    if 'number' not in session:
        session['number'] = random.randint(1, 100)
        session['attempts'] = 0
        message = 'Guess a number between 1 and 100!'
    else:
        message = ''

    if request.method == 'POST':
        try:
            guess = int(request.form['guess'])
            session['attempts'] += 1

            if guess < session['number']:
                message = 'Too low! Try again.'
            elif guess > session['number']:
                message = 'Too high! Try again.'
            else:
                message = f'You got it! The number was {session["number"]}. It took {session["attempts"]} attempts.'
                # Reset for new game
                del session['number']
                del session['attempts']
        except ValueError:
            message = 'Invalid input. Enter a number between 1 and 100.'

    # Inline HTML template
    html = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Number Guessing Game</title>
        <style>
            body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; }
            h1 { color: #333; }
            form { margin: 20px; }
            input[type="number"] { padding: 10px; width: 200px; }
            input[type="submit"] { padding: 10px 20px; background: #007bff; color: white; border: none; cursor: pointer; }
            p { font-size: 18px; color: #555; }
        </style>
    </head>
    <body>
        <h1>Number Guessing Game</h1>
        <form method="post">
            <input type="number" name="guess" min="1" max="100" required placeholder="Enter your guess">
            <input type="submit" value="Guess">
        </form>
        <p>{{ message }}</p>
    </body>
    </html>
    """

    return render_template_string(html, message=message)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000, debug=True)
# Python CI/CD Test-1 - Fri Aug 22 09:38:27 AM PKT 2025
# Python CI/CD Test-2 - Fri Aug 22 11:02:28 AM PKT 2025
# Python CI/CD Test-Sat Aug 23 09:20:32 PM PKT 2025
