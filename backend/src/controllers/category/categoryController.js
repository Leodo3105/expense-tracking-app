import Category from '../../models/category.js';

// Thêm danh mục mới
export const addCategory = async (req, res) => {
  const { name, type } = req.body;

  try {
    
    const newCategory = await Category.create({
      name,
      type,
      userId: req.user.id, // Lấy ID người dùng từ token
    });

    res.status(201).json(newCategory);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Lấy danh sách danh mục
export const getCategories = async (req, res) => {
  try {
    const categories = await Category.findAll({
      where: { userId: req.user.id }, // Lọc danh mục theo người dùng
    });

    res.status(200).json(categories);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Cập nhật danh mục
export const updateCategory = async (req, res) => {
  const { id } = req.params;
  const { name, type } = req.body;

  try {
    const category = await Category.findOne({
      where: { id, userId: req.user.id }, // Xác minh danh mục thuộc người dùng
    });

    if (!category) {
      return res.status(404).json({ error: 'Danh mục không tồn tại!' });
    }

    category.name = name || category.name;
    category.type = type || category.type;
    await category.save();

    res.status(200).json(category);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Xóa danh mục
export const deleteCategory = async (req, res) => {
  const { id } = req.params;

  try {
    const category = await Category.findOne({
      where: { id, userId: req.user.id }, // Xác minh danh mục thuộc người dùng
    });

    if (!category) {
      return res.status(404).json({ error: 'Danh mục không tồn tại!' });
    }

    await category.destroy();
    res.status(200).json({ message: 'Danh mục đã được xóa!' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
