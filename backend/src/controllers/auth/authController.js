import bcrypt from 'bcrypt';
import User from '../../models/user.js';
import jwt from 'jsonwebtoken';

// Biểu thức chính quy để kiểm tra email hợp lệ
const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

// Đăng ký
export const register = async (req, res) => {
  const { name, email, password } = req.body;

  try {
    // Kiểm tra email có hợp lệ không
    if (!emailRegex.test(email)) {
      return res.status(400).json({ error: 'Email không hợp lệ!' });
    }

    // Kiểm tra password có đủ mạnh không
    if (password.length < 8) {
      return res.status(400).json({
        error: 'Mật khẩu phải có ít nhất 8 ký tự!',
      });
    }

    if (!/[A-Z]/.test(password)) {
      return res.status(400).json({
        error: 'Mật khẩu phải chứa ít nhất 1 chữ cái viết hoa!',
      });
    }

    if (!/[a-z]/.test(password)) {
      return res.status(400).json({
        error: 'Mật khẩu phải chứa ít nhất 1 chữ cái thường!',
      });
    }

    if (!/\d/.test(password)) {
      return res.status(400).json({
        error: 'Mật khẩu phải chứa ít nhất 1 chữ số!',
      });
    }

    if (!/[!@#$%^&*(),.?":{}|<>]/.test(password)) {
      return res.status(400).json({
        error: 'Mật khẩu phải chứa ít nhất 1 ký tự đặc biệt!',
      });
    }

    // Kiểm tra email đã tồn tại chưa
    const existingUser = await User.findOne({ where: { email } });

    if (existingUser) {
      return res.status(400).json({ error: 'Email đã tồn tại!' });
    }

    // Mã hóa mật khẩu
    const hashedPassword = await bcrypt.hash(password, 10);

    // Lưu người dùng mới vào database
    const newUser = await User.create({
      name,
      email,
      password: hashedPassword,
    });

    // Tạo token
    const token = jwt.sign(
        { id: newUser.id, email: newUser.email },
        process.env.JWT_SECRET,
        { expiresIn: '1h' }
    );

    res.status(201).json({
      message: 'Đăng ký thành công!',
      token: token, // Trả về token
      user: {
        id: newUser.id,
        name: newUser.name,
        email: newUser.email,
      },
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

export const login = async (req, res) => {
    const { email, password } = req.body;
  
    try {
      // Tìm người dùng bằng email
      const user = await User.findOne({ where: { email } });
  
      if (!user) {
        return res.status(404).json({ error: 'Email không tồn tại!' });
      }
  
      // Kiểm tra mật khẩu
      const isMatch = await bcrypt.compare(password, user.password);
      if (!isMatch) {
        return res.status(401).json({ error: 'Mật khẩu không đúng!' });
      }
  
      // Tạo JWT token
      const token = jwt.sign({ id: user.id, email: user.email }, process.env.JWT_SECRET, {
        expiresIn: '1d', // Token hết hạn sau 1 ngày
      });
  
      res.status(200).json({
        message: 'Đăng nhập thành công!',
        token,
        name: user.name,
      });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
};