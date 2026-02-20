import { TestBed } from '@angular/core/testing';
import { provideHttpClient } from '@angular/common/http';
import { provideHttpClientTesting, HttpTestingController } from '@angular/common/http/testing';
import { UserService } from './user.service';
import { User } from '../models/user.interface';

describe('UserService', () => {
  let service: UserService;
  let httpMock: HttpTestingController;
  const apiUrl = 'http://localhost:8080/api/users';

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [
        UserService,
        provideHttpClient(),
        provideHttpClientTesting()
      ]
    });
    service = TestBed.inject(UserService);
    httpMock = TestBed.inject(HttpTestingController);
  });

  afterEach(() => {
    httpMock.verify();
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });

  describe('getUsers', () => {
    it('should return an Observable<User[]>', () => {
      const mockUsers: User[] = [
        {
          id: 1,
          name: 'John Doe',
          email: 'john@example.com',
          username: 'johndoe',
          phone: '+1-555-1234'
        },
        {
          id: 2,
          name: 'Jane Smith',
          email: 'jane@example.com',
          username: 'janesmith',
          phone: '+1-555-5678'
        }
      ];

      service.getUsers().subscribe(users => {
        expect(users).toEqual(mockUsers);
        expect(users.length).toBe(2);
        expect(users[0].name).toBe('John Doe');
        expect(users[1].name).toBe('Jane Smith');
      });

      const req = httpMock.expectOne(apiUrl);
      expect(req.request.method).toBe('GET');
      req.flush(mockUsers);
    });

    it('should return an empty array when no users exist', () => {
      const mockUsers: User[] = [];

      service.getUsers().subscribe(users => {
        expect(users).toEqual([]);
        expect(users.length).toBe(0);
      });

      const req = httpMock.expectOne(apiUrl);
      expect(req.request.method).toBe('GET');
      req.flush(mockUsers);
    });

    it('should handle users without optional fields', () => {
      const mockUsers: User[] = [
        {
          id: 1,
          name: 'John Doe',
          email: 'john@example.com'
        }
      ];

      service.getUsers().subscribe(users => {
        expect(users).toEqual(mockUsers);
        expect(users[0].username).toBeUndefined();
        expect(users[0].phone).toBeUndefined();
      });

      const req = httpMock.expectOne(apiUrl);
      req.flush(mockUsers);
    });

    it('should handle HTTP error responses', () => {
      const errorMessage = 'Server error';

      service.getUsers().subscribe({
        next: () => {
          throw new Error('should have failed with 500 error');
        },
        error: (error) => {
          expect(error.status).toBe(500);
          expect(error.statusText).toBe('Server Error');
        }
      });

      const req = httpMock.expectOne(apiUrl);
      req.flush(errorMessage, { status: 500, statusText: 'Server Error' });
    });

    it('should handle network errors', () => {
      const errorEvent = new ProgressEvent('Network error');

      service.getUsers().subscribe({
        next: () => {
          throw new Error('should have failed with network error');
        },
        error: (error) => {
          expect(error.error).toBe(errorEvent);
        }
      });

      const req = httpMock.expectOne(apiUrl);
      req.error(errorEvent);
    });
  });

  describe('getUserById', () => {
    it('should return a single user by id', () => {
      const mockUser: User = {
        id: 1,
        name: 'John Doe',
        email: 'john@example.com',
        username: 'johndoe',
        phone: '+1-555-1234'
      };

      service.getUserById(1).subscribe(user => {
        expect(user).toEqual(mockUser);
        expect(user.id).toBe(1);
        expect(user.name).toBe('John Doe');
        expect(user.email).toBe('john@example.com');
      });

      const req = httpMock.expectOne(`${apiUrl}/1`);
      expect(req.request.method).toBe('GET');
      req.flush(mockUser);
    });

    it('should construct correct URL for different user ids', () => {
      const mockUser: User = {
        id: 42,
        name: 'Test User',
        email: 'test@example.com'
      };

      service.getUserById(42).subscribe();

      const req = httpMock.expectOne(`${apiUrl}/42`);
      expect(req.request.method).toBe('GET');
      req.flush(mockUser);
    });

    it('should handle user without optional fields', () => {
      const mockUser: User = {
        id: 1,
        name: 'John Doe',
        email: 'john@example.com'
      };

      service.getUserById(1).subscribe(user => {
        expect(user).toEqual(mockUser);
        expect(user.username).toBeUndefined();
        expect(user.phone).toBeUndefined();
      });

      const req = httpMock.expectOne(`${apiUrl}/1`);
      req.flush(mockUser);
    });

    it('should handle 404 error when user not found', () => {
      service.getUserById(999).subscribe({
        next: () => {
          throw new Error('should have failed with 404 error');
        },
        error: (error) => {
          expect(error.status).toBe(404);
          expect(error.statusText).toBe('Not Found');
        }
      });

      const req = httpMock.expectOne(`${apiUrl}/999`);
      req.flush('User not found', { status: 404, statusText: 'Not Found' });
    });

    it('should handle HTTP error responses', () => {
      service.getUserById(1).subscribe({
        next: () => {
          throw new Error('should have failed with 500 error');
        },
        error: (error) => {
          expect(error.status).toBe(500);
        }
      });

      const req = httpMock.expectOne(`${apiUrl}/1`);
      req.flush('Server error', { status: 500, statusText: 'Server Error' });
    });

    it('should handle multiple sequential requests', () => {
      const mockUser1: User = {
        id: 1,
        name: 'User 1',
        email: 'user1@example.com'
      };

      const mockUser2: User = {
        id: 2,
        name: 'User 2',
        email: 'user2@example.com'
      };

      service.getUserById(1).subscribe(user => {
        expect(user).toEqual(mockUser1);
      });

      service.getUserById(2).subscribe(user => {
        expect(user).toEqual(mockUser2);
      });

      const req1 = httpMock.expectOne(`${apiUrl}/1`);
      const req2 = httpMock.expectOne(`${apiUrl}/2`);

      req1.flush(mockUser1);
      req2.flush(mockUser2);
    });
  });

  describe('API URL configuration', () => {
    it('should use correct base URL', () => {
      service.getUsers().subscribe();

      const req = httpMock.expectOne(apiUrl);
      expect(req.request.url).toBe('http://localhost:8080/api/users');
      req.flush([]);
    });

    it('should construct correct URL with path parameters', () => {
      service.getUserById(123).subscribe();

      const req = httpMock.expectOne(`${apiUrl}/123`);
      expect(req.request.url).toBe('http://localhost:8080/api/users/123');
      req.flush({} as User);
    });
  });
});
