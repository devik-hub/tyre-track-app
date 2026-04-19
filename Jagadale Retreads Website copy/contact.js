function submitForm(event) {
  event.preventDefault();

  var name = document.getElementById("name").value;
  var email = document.getElementById("email").value;
  var phoneNumber = document.getElementById("phone number").value;
  var address = document.getElementById("address").value;
  var searchingFor = document.getElementById("searching for").value;

  console.log("Name:", name);
  console.log("Email:", email);
  console.log("Phone Number:", phoneNumber);
  console.log("Address:", address);
  console.log("Searching For:", searchingFor);

  // Additional validation logic can be added here

  // Send the form data to the server-side script using AJAX
  var xhr = new XMLHttpRequest();
  xhr.open("POST", "submit_contact_form.php", true);
  xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
  xhr.onreadystatechange = function () {
    if (xhr.readyState === XMLHttpRequest.DONE) {
      if (xhr.status === 200) {
        // Form submission successful
        document.getElementById("successMessage").style.display = "block";
        document.getElementById("contactForm").reset();
      } else {
        // Form submission failed
        console.error("Error submitting form:", xhr.responseText);
        console.error("Status:", xhr.status);
        console.error("Status Text:", xhr.statusText);
        alert("Error submitting form");
      }
    }
  };
  xhr.send(
    "name=" +
      encodeURIComponent(name) +
      "&email=" +
      encodeURIComponent(email) +
      "&phone_number=" +
      encodeURIComponent(phoneNumber) +
      "&address=" +
      encodeURIComponent(address) +
      "&searching_for=" +
      encodeURIComponent(searchingFor)
  );
}
