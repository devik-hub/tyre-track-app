// Object-oriented structure for Jagadale Retreads
class JagadaleRetreads {
    constructor() {
        this.init();
    }

    init() {
        this.setupNavigation();
        this.setupAnimations();
        this.setupForms();
        this.setupGallery();
        this.setupProductFilters();
    }

    setupNavigation() {
        // Responsive navigation menu
        const menuToggle = document.querySelector('.menu-toggle');
        const menu = document.querySelector('.menu');
        
        if (menuToggle && menu) {
            menuToggle.addEventListener('click', () => {
                menu.classList.toggle('active');
            });
        }

        // Smooth scrolling
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if (target) {
                    target.scrollIntoView({
                        behavior: 'smooth'
                    });
                }
            });
        });
    }

    setupAnimations() {
        // Add fade-in animation to elements
        const animateElements = document.querySelectorAll('.animate-on-scroll');
        
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('fade-in');
                }
            });
        });

        animateElements.forEach(el => observer.observe(el));
    }

    setupForms() {
        // Contact form validation
        const contactForm = document.getElementById('contactForm');
        if (contactForm) {
            contactForm.addEventListener('submit', (e) => {
                e.preventDefault();
                if (this.validateForm(contactForm)) {
                    this.submitForm(contactForm);
                }
            });
        }
    }

    validateForm(form) {
        let isValid = true;
        const inputs = form.querySelectorAll('input, textarea');
        
        inputs.forEach(input => {
            if (input.hasAttribute('required') && !input.value.trim()) {
                isValid = false;
                this.showError(input, 'This field is required');
            } else if (input.type === 'email' && input.value) {
                const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                if (!emailRegex.test(input.value)) {
                    isValid = false;
                    this.showError(input, 'Please enter a valid email address');
                }
            } else if (input.type === 'tel' && input.value) {
                const phoneRegex = /^\d{10}$/;
                if (!phoneRegex.test(input.value)) {
                    isValid = false;
                    this.showError(input, 'Please enter a valid 10-digit phone number');
                }
            }
        });

        return isValid;
    }

    showError(input, message) {
        const errorDiv = document.createElement('div');
        errorDiv.className = 'error-message';
        errorDiv.textContent = message;
        input.parentNode.appendChild(errorDiv);
        
        setTimeout(() => {
            errorDiv.remove();
        }, 3000);
    }

    submitForm(form) {
        // Simulate form submission
        const formData = new FormData(form);
        const data = {};
        formData.forEach((value, key) => data[key] = value);
        
        // Show success message
        const successMessage = document.createElement('div');
        successMessage.className = 'success-message';
        successMessage.textContent = 'Thank you for your message! We will get back to you soon.';
        form.appendChild(successMessage);
        
        // Clear form
        form.reset();
        
        setTimeout(() => {
            successMessage.remove();
        }, 3000);
    }

    setupGallery() {
        // Gallery lightbox and filtering
        const gallery = document.querySelector('.gallery');
        if (gallery) {
            const images = gallery.querySelectorAll('img');
            images.forEach(img => {
                img.addEventListener('click', () => {
                    this.openLightbox(img.src);
                });
            });

            // Gallery filters
            const filters = document.querySelectorAll('.gallery-filter');
            filters.forEach(filter => {
                filter.addEventListener('click', () => {
                    const category = filter.getAttribute('data-category');
                    this.filterGallery(category);
                });
            });
        }
    }

    openLightbox(src) {
        const lightbox = document.createElement('div');
        lightbox.className = 'lightbox';
        lightbox.innerHTML = `
            <div class="lightbox-content">
                <img src="${src}" alt="Gallery Image">
                <button class="close-lightbox">&times;</button>
            </div>
        `;
        document.body.appendChild(lightbox);

        lightbox.querySelector('.close-lightbox').addEventListener('click', () => {
            lightbox.remove();
        });
    }

    filterGallery(category) {
        const items = document.querySelectorAll('.gallery-item');
        items.forEach(item => {
            if (category === 'all' || item.getAttribute('data-category') === category) {
                item.style.display = 'block';
            } else {
                item.style.display = 'none';
            }
        });
    }

    setupProductFilters() {
        // Product filtering and sorting
        const productFilters = document.querySelectorAll('.product-filter');
        if (productFilters.length > 0) {
            productFilters.forEach(filter => {
                filter.addEventListener('click', () => {
                    const category = filter.getAttribute('data-category');
                    this.filterProducts(category);
                });
            });
        }
    }

    filterProducts(category) {
        const products = document.querySelectorAll('.product-item');
        products.forEach(product => {
            if (category === 'all' || product.getAttribute('data-category') === category) {
                product.style.display = 'block';
            } else {
                product.style.display = 'none';
            }
        });
    }
}

// Initialize the application
document.addEventListener('DOMContentLoaded', () => {
    const app = new JagadaleRetreads();
});
