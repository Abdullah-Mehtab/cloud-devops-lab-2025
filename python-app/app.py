"""Simple number guessing Flask application."""

import os
import random
from textwrap import dedent

from flask import Flask, request, render_template_string, session

# Configuration
SECRET_KEY = os.environ.get("SECRET_KEY", "change_this_in_prod")

app = Flask(__name__)
app.config["SECRET_KEY"] = SECRET_KEY


@app.route("/", methods=("GET", "POST"))
def guess():
    """Main view: play a number guessing game stored in session."""
    # Initialize game if not started
    if session.get("number") is None:
        session["number"] = random.randint(1, 100)
        session["attempts"] = 0
        message = "Guess a number between 1 and 100!"
    else:
        message = ""

    if request.method == "POST":
        form_value = request.form.get("guess", "").strip()
        try:
            guess_value = int(form_value)
            session["attempts"] = session.get("attempts", 0) + 1

            if guess_value < session["number"]:
                message = "Too low! Try again."
            elif guess_value > session["number"]:
                message = "Too high! Try again."
            else:
                message = (
                    "You got it! The number was {num}. "
                    "It took {attempts} attempts."
                ).format(num=session["number"], attempts=session["attempts"])
                # Reset for a new game
                session.pop("number", None)
                session.pop("attempts", None)
        except (ValueError, TypeError):
            message = "Invalid input. Enter a number between 1 and 100."

    # Inline HTML template (kept readable & line-length-safe)
    html = dedent(
        """\
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Number Guessing Game</title>
            <style>
                body {
                    font-family: Arial, sans-serif;
                    text-align: center;
                    margin-top: 50px;
                }

                h1 {
                    color: #333;
                }

                form {
                    margin: 20px;
                }

                input[type="number"] {
                    padding: 10px;
                    width: 200px;
                }

                input[type="submit"] {
                    padding: 10px 20px;
                    background: #007bff;
                    color: white;
                    border: none;
                    cursor: pointer;
                }

                p {
                    font-size: 18px;
                    color: #555;
                }
            </style>
        </head>
        <body>
            <h1>Number Guessing Game</h1>
            <form method="post" novalidate>
                <input
                    type="number"
                    name="guess"
                    min="1"
                    max="100"
                    required
                    placeholder="Enter your guess"
                >
                <input type="submit" value="Guess">
            </form>
            <p>{{ message }}</p>
        </body>
        </html>
        """
    )

    return render_template_string(html, message=message)


if __name__ == "__main__":
    # Run the app on all interfaces on port 8000 for local testing.
    app.run(host="0.0.0.0", port=8000, debug=True)
