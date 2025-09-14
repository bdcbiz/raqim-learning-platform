const API_BASE_URL = 'http://localhost:5000/api/v1';

class ApiService {
    constructor() {
        this.token = localStorage.getItem('auth_token');
    }

    getHeaders() {
        const headers = {
            'Content-Type': 'application/json',
        };
        
        if (this.token) {
            headers['Authorization'] = `Bearer ${this.token}`;
        }
        
        return headers;
    }

    saveToken(token) {
        this.token = token;
        localStorage.setItem('auth_token', token);
    }

    clearToken() {
        this.token = null;
        localStorage.removeItem('auth_token');
    }

    async handleResponse(response) {
        const data = await response.json();
        
        if (!response.ok) {
            throw new Error(data.error || 'Something went wrong');
        }
        
        return data;
    }

    // Auth Methods
    async register(name, email, password, role = 'student') {
        const response = await fetch(`${API_BASE_URL}/auth/register`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ name, email, password, role }),
        });

        const data = await this.handleResponse(response);
        
        if (data.token) {
            this.saveToken(data.token);
        }
        
        return data;
    }

    async login(email, password) {
        const response = await fetch(`${API_BASE_URL}/auth/login`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ email, password }),
        });

        const data = await this.handleResponse(response);
        
        if (data.token) {
            this.saveToken(data.token);
        }
        
        return data;
    }

    async getProfile() {
        const response = await fetch(`${API_BASE_URL}/auth/me`, {
            headers: this.getHeaders(),
        });

        return await this.handleResponse(response);
    }

    async logout() {
        await fetch(`${API_BASE_URL}/auth/logout`, {
            method: 'POST',
            headers: this.getHeaders(),
        });
        
        this.clearToken();
    }

    async updateProfile(profileData) {
        const response = await fetch(`${API_BASE_URL}/auth/updateprofile`, {
            method: 'PUT',
            headers: this.getHeaders(),
            body: JSON.stringify(profileData),
        });

        return await this.handleResponse(response);
    }

    // Course Methods
    async getCourses(params = {}) {
        const queryString = new URLSearchParams(params).toString();
        const url = `${API_BASE_URL}/courses${queryString ? '?' + queryString : ''}`;
        
        const response = await fetch(url, {
            headers: this.getHeaders(),
        });

        return await this.handleResponse(response);
    }

    async getCourse(courseId) {
        const response = await fetch(`${API_BASE_URL}/courses/${courseId}`, {
            headers: this.getHeaders(),
        });

        return await this.handleResponse(response);
    }

    async enrollInCourse(courseId) {
        const response = await fetch(`${API_BASE_URL}/courses/${courseId}/enroll`, {
            method: 'POST',
            headers: this.getHeaders(),
        });

        return await this.handleResponse(response);
    }

    async getEnrolledCourses() {
        const response = await fetch(`${API_BASE_URL}/courses/enrolled`, {
            headers: this.getHeaders(),
        });

        return await this.handleResponse(response);
    }

    async addReview(courseId, rating, comment) {
        const response = await fetch(`${API_BASE_URL}/courses/${courseId}/reviews`, {
            method: 'POST',
            headers: this.getHeaders(),
            body: JSON.stringify({ rating, comment }),
        });

        return await this.handleResponse(response);
    }

    // Lesson Methods
    async getLessons(courseId) {
        const response = await fetch(`${API_BASE_URL}/lessons/course/${courseId}`, {
            headers: this.getHeaders(),
        });

        return await this.handleResponse(response);
    }

    async getLesson(lessonId) {
        const response = await fetch(`${API_BASE_URL}/lessons/${lessonId}`, {
            headers: this.getHeaders(),
        });

        return await this.handleResponse(response);
    }

    async completeLesson(lessonId, score = null, timeSpent = null) {
        const body = {};
        if (score !== null) body.score = score;
        if (timeSpent !== null) body.timeSpent = timeSpent;

        const response = await fetch(`${API_BASE_URL}/lessons/${lessonId}/complete`, {
            method: 'POST',
            headers: this.getHeaders(),
            body: JSON.stringify(body),
        });

        return await this.handleResponse(response);
    }

    async addComment(lessonId, text) {
        const response = await fetch(`${API_BASE_URL}/lessons/${lessonId}/comment`, {
            method: 'POST',
            headers: this.getHeaders(),
            body: JSON.stringify({ text }),
        });

        return await this.handleResponse(response);
    }

    async submitQuiz(lessonId, answers) {
        const response = await fetch(`${API_BASE_URL}/lessons/${lessonId}/quiz/submit`, {
            method: 'POST',
            headers: this.getHeaders(),
            body: JSON.stringify({ answers }),
        });

        return await this.handleResponse(response);
    }

    // Progress Methods
    async getCourseProgress(courseId) {
        const response = await fetch(`${API_BASE_URL}/progress/course/${courseId}`, {
            headers: this.getHeaders(),
        });

        return await this.handleResponse(response);
    }

    async getAllProgress() {
        const response = await fetch(`${API_BASE_URL}/progress`, {
            headers: this.getHeaders(),
        });

        return await this.handleResponse(response);
    }

    async getStatistics() {
        const response = await fetch(`${API_BASE_URL}/progress/statistics`, {
            headers: this.getHeaders(),
        });

        return await this.handleResponse(response);
    }

    async addNote(courseId, lessonId, content) {
        const response = await fetch(`${API_BASE_URL}/progress/course/${courseId}/notes`, {
            method: 'POST',
            headers: this.getHeaders(),
            body: JSON.stringify({ lessonId, content }),
        });

        return await this.handleResponse(response);
    }

    async addBookmark(courseId, lessonId, timestamp, note) {
        const response = await fetch(`${API_BASE_URL}/progress/course/${courseId}/bookmarks`, {
            method: 'POST',
            headers: this.getHeaders(),
            body: JSON.stringify({ lessonId, timestamp, note }),
        });

        return await this.handleResponse(response);
    }

    async getCertificate(courseId) {
        const response = await fetch(`${API_BASE_URL}/progress/course/${courseId}/certificate`, {
            headers: this.getHeaders(),
        });

        return await this.handleResponse(response);
    }

    // Upload Methods
    async uploadFile(endpoint, file, fieldName) {
        const formData = new FormData();
        formData.append(fieldName, file);

        const headers = {};
        if (this.token) {
            headers['Authorization'] = `Bearer ${this.token}`;
        }

        const response = await fetch(`${API_BASE_URL}/upload/${endpoint}`, {
            method: 'POST',
            headers: headers,
            body: formData,
        });

        return await this.handleResponse(response);
    }

    async uploadAvatar(file) {
        return await this.uploadFile('avatar', file, 'avatar');
    }

    async uploadThumbnail(file) {
        return await this.uploadFile('thumbnail', file, 'thumbnail');
    }

    async uploadVideo(file) {
        return await this.uploadFile('video', file, 'video');
    }

    async uploadMaterial(file) {
        return await this.uploadFile('material', file, 'material');
    }
}

// Create a global instance
const apiService = new ApiService();

// Export for use in other scripts
if (typeof module !== 'undefined' && module.exports) {
    module.exports = ApiService;
}