<?php
// Validate form inputs
$name = filter_input(INPUT_POST, 'name', FILTER_SANITIZE_STRING);
$email = filter_input(INPUT_POST, 'email', FILTER_SANITIZE_EMAIL);
$message = filter_input(INPUT_POST, 'message', FILTER_SANITIZE_STRING);

// Check if inputs are empty
if (empty($name) || empty($email) || empty($message)) {
  die('Invalid form submission');
}

// Send email
$to = 'your_email@example.com';
$subject = 'Contact Form Submission';
$body = "Name: $name\nEmail: $email\nMessage:\n$message";
$headers = 'From: ' . $email;

if (mail($to, $subject, $body, $headers)) {
  echo 'Email sent successfully';
} else {
  echo 'Failed to send email';
}
?>