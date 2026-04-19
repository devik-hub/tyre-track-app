$(document).ready(function () {
    // Load saved orders when page loads
    displaySavedOrders();

    // Handle form submission
    $("#tireOrderForm").submit(function (e) {
        e.preventDefault();

        // Get form data
        const order = {
            id: Date.now(), // Unique ID for the order
            name: $("#customerName").val(),
            location: $("#customerLocation").val(),
            tireSize: $("#tireSize").val(),
            quantity: $("#quantity").val(),
            notes: $("#notes").val(),
            date: new Date().toLocaleDateString(),
        };

        // Get existing orders from localStorage
        let orders = JSON.parse(localStorage.getItem("tireOrders") || "[]");

        // Add new order
        orders.push(order);

        // Save back to localStorage
        localStorage.setItem("tireOrders", JSON.stringify(orders));

        // Reset form
        this.reset();

        // Update display
        displaySavedOrders();

        alert("Order saved successfully!");
    });

    // Function to display saved orders
    function displaySavedOrders() {
        const orders = JSON.parse(localStorage.getItem("tireOrders") || "[]");
        const ordersHtml = orders
            .map(
                (order) => `
            <div class="card mb-3">
                <div class="card-body">
                    <h5 class="card-title">${order.name}</h5>
                    <p class="card-text">
                        <strong>Location:</strong> ${order.location}<br>
                        <strong>Tire Size:</strong> ${order.tireSize}<br>
                        <strong>Quantity:</strong> ${order.quantity}<br>
                        <strong>Date:</strong> ${order.date}<br>
                        ${order.notes ? `<strong>Notes:</strong> ${order.notes}<br>` : ""}
                    </p>
                    <button class="btn btn-danger btn-sm" onclick="deleteOrder(${order.id})">Delete</button>
                </div>
            </div>
        `
            )
            .join("");

        $("#savedOrders").html(ordersHtml || "<p>No saved orders</p>");
    }

    // Add global function to delete orders
    window.deleteOrder = function (orderId) {
        if (confirm("Are you sure you want to delete this order?")) {
            let orders = JSON.parse(localStorage.getItem("tireOrders") || "[]");
            orders = orders.filter((order) => order.id !== orderId);
            localStorage.setItem("tireOrders", JSON.stringify(orders));
            displaySavedOrders();
        }
    };
});
