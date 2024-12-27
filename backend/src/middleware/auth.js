import jwt from 'jsonwebtoken'; // Import toàn bộ module jsonwebtoken
import dotenv from 'dotenv';     // Import dotenv

dotenv.config(); // Load environment variables

const { verify } = jwt; // Destructure verify từ jwt

// Middleware để kiểm tra JWT token
const authenticateToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.startsWith('Bearer ') ? authHeader.split(' ')[1] : null;

    if (!token) {
        return res.status(401).json({ code: 'UNAUTHORIZED', message: 'Access denied.' });
    }

    if (!process.env.JWT_SECRET) {
        console.error('JWT_SECRET is not defined in environment variables.');
        return res.status(500).json({ code: 'SERVER_ERROR', message: 'Server configuration error.' });
    }

    try {
        const decoded = verify(token, process.env.JWT_SECRET);
        console.log('Token decoded successfully. User ID:', decoded.id);

        req.user = decoded;
        next(); // Tiếp tục đến middleware hoặc controller tiếp theo
    } catch (err) {
        console.error('Error decoding token:', err);

        if (err.name === 'TokenExpiredError') {
            return res.status(403).json({ code: 'TOKEN_EXPIRED', message: 'Token expired. Please log in again.' });
        } else if (err.name === 'JsonWebTokenError') {
            return res.status(403).json({ code: 'INVALID_TOKEN', message: 'Invalid token. Please log in again.' });
        } else if (err.name === 'NotBeforeError') {
            return res.status(403).json({ code: 'TOKEN_NOT_ACTIVE', message: 'Token not active yet.' });
        } else {
            return res.status(500).json({ code: 'TOKEN_PROCESSING_ERROR', message: 'An error occurred while processing the token.' });
        }
    }
};

export { authenticateToken };
