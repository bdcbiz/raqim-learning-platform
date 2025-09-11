// Initialize API Service
document.addEventListener('DOMContentLoaded', async function() {
    // Check if user is logged in
    const token = localStorage.getItem('auth_token');
    if (token) {
        try {
            const profile = await apiService.getProfile();
            updateUIForLoggedInUser(profile.data);
        } catch (error) {
            console.error('Failed to get profile:', error);
            localStorage.removeItem('auth_token');
        }
    }
    
    // Initialize event listeners
    initializeEventListeners();
    
    // Load courses
    loadCourses();
});

function updateUIForLoggedInUser(user) {
    // Update navigation
    const loginBtn = document.getElementById('loginBtn');
    const signupBtn = document.getElementById('signupBtn');
    const userMenu = document.getElementById('userMenu');
    
    if (loginBtn) loginBtn.style.display = 'none';
    if (signupBtn) signupBtn.style.display = 'none';
    
    if (userMenu) {
        userMenu.innerHTML = `
            <div class="dropdown">
                <button class="btn btn-link dropdown-toggle" type="button" id="userDropdown" data-bs-toggle="dropdown">
                    <img src="${user.avatar || '/images/default-avatar.png'}" class="rounded-circle" width="40" height="40">
                    ${user.name}
                </button>
                <ul class="dropdown-menu" aria-labelledby="userDropdown">
                    <li><a class="dropdown-item" href="/dashboard">لوحة التحكم</a></li>
                    <li><a class="dropdown-item" href="/profile">الملف الشخصي</a></li>
                    <li><a class="dropdown-item" href="/my-courses">دوراتي</a></li>
                    <li><hr class="dropdown-divider"></li>
                    <li><a class="dropdown-item" href="#" onclick="logout()">تسجيل الخروج</a></li>
                </ul>
            </div>
        `;
        userMenu.style.display = 'block';
    }
}

function initializeEventListeners() {
    // Login form
    const loginForm = document.getElementById('loginForm');
    if (loginForm) {
        loginForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            const email = document.getElementById('email').value;
            const password = document.getElementById('password').value;
            
            try {
                const response = await apiService.login(email, password);
                if (response.success) {
                    window.location.href = '/dashboard';
                }
            } catch (error) {
                showAlert('خطأ في تسجيل الدخول: ' + error.message, 'danger');
            }
        });
    }
    
    // Signup form
    const signupForm = document.getElementById('signupForm');
    if (signupForm) {
        signupForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            const name = document.getElementById('name').value;
            const email = document.getElementById('email').value;
            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            
            if (password !== confirmPassword) {
                showAlert('كلمات المرور غير متطابقة', 'danger');
                return;
            }
            
            try {
                const response = await apiService.register(name, email, password);
                if (response.success) {
                    window.location.href = '/dashboard';
                }
            } catch (error) {
                showAlert('خطأ في التسجيل: ' + error.message, 'danger');
            }
        });
    }
    
    // Course enrollment buttons
    document.addEventListener('click', async (e) => {
        if (e.target.classList.contains('enroll-btn')) {
            const courseId = e.target.dataset.courseId;
            try {
                const response = await apiService.enrollInCourse(courseId);
                if (response.success) {
                    showAlert('تم التسجيل في الدورة بنجاح', 'success');
                    e.target.textContent = 'تم التسجيل';
                    e.target.disabled = true;
                }
            } catch (error) {
                showAlert('خطأ في التسجيل: ' + error.message, 'danger');
            }
        }
    });
}

async function loadCourses() {
    const coursesContainer = document.getElementById('coursesContainer');
    if (!coursesContainer) return;
    
    try {
        const response = await apiService.getCourses({ limit: 12 });
        if (response.success) {
            displayCourses(response.data, coursesContainer);
        }
    } catch (error) {
        console.error('Failed to load courses:', error);
    }
}

function displayCourses(courses, container) {
    container.innerHTML = '';
    
    courses.forEach(course => {
        const courseCard = createCourseCard(course);
        container.appendChild(courseCard);
    });
}

function createCourseCard(course) {
    const div = document.createElement('div');
    div.className = 'col-md-4 mb-4';
    
    const isArabic = document.documentElement.lang === 'ar';
    const title = isArabic ? course.titleAr : course.title;
    const description = isArabic ? course.descriptionAr : course.description;
    
    div.innerHTML = `
        <div class="card h-100">
            <img src="${course.thumbnail || '/images/default-course.jpg'}" class="card-img-top" alt="${title}">
            <div class="card-body">
                <h5 class="card-title">${title}</h5>
                <p class="card-text">${description}</p>
                <div class="d-flex justify-content-between align-items-center">
                    <span class="badge bg-primary">${course.level}</span>
                    <span class="text-muted">${course.totalLessons} دروس</span>
                </div>
                <div class="mt-2">
                    <small class="text-muted">المدرس: ${course.instructor.name}</small>
                </div>
                <div class="mt-2">
                    ${renderStars(course.rating)}
                    <small>(${course.numberOfRatings} تقييم)</small>
                </div>
            </div>
            <div class="card-footer">
                <div class="d-flex justify-content-between align-items-center">
                    ${course.isFree ? 
                        '<span class="badge bg-success">مجاني</span>' : 
                        `<span class="fw-bold">${course.price} ${course.currency}</span>`
                    }
                    <button class="btn btn-primary btn-sm enroll-btn" data-course-id="${course._id}">
                        التسجيل في الدورة
                    </button>
                </div>
            </div>
        </div>
    `;
    
    return div;
}

function renderStars(rating) {
    let stars = '';
    for (let i = 1; i <= 5; i++) {
        if (i <= rating) {
            stars += '<i class="fas fa-star text-warning"></i>';
        } else if (i - 0.5 <= rating) {
            stars += '<i class="fas fa-star-half-alt text-warning"></i>';
        } else {
            stars += '<i class="far fa-star text-warning"></i>';
        }
    }
    return stars;
}

function showAlert(message, type) {
    const alertContainer = document.getElementById('alertContainer') || document.body;
    const alert = document.createElement('div');
    alert.className = `alert alert-${type} alert-dismissible fade show`;
    alert.innerHTML = `
        ${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    `;
    alertContainer.insertBefore(alert, alertContainer.firstChild);
    
    setTimeout(() => {
        alert.remove();
    }, 5000);
}

async function logout() {
    try {
        await apiService.logout();
        window.location.href = '/';
    } catch (error) {
        console.error('Logout failed:', error);
        localStorage.removeItem('auth_token');
        window.location.href = '/';
    }
}

// Search functionality
async function searchCourses(query) {
    try {
        const response = await apiService.getCourses({ search: query });
        if (response.success) {
            const coursesContainer = document.getElementById('coursesContainer');
            displayCourses(response.data, coursesContainer);
        }
    } catch (error) {
        console.error('Search failed:', error);
    }
}

// Filter functionality
async function filterCourses(filters) {
    try {
        const response = await apiService.getCourses(filters);
        if (response.success) {
            const coursesContainer = document.getElementById('coursesContainer');
            displayCourses(response.data, coursesContainer);
        }
    } catch (error) {
        console.error('Filter failed:', error);
    }
}

// Export functions for global use
window.apiService = apiService;
window.logout = logout;
window.searchCourses = searchCourses;
window.filterCourses = filterCourses;