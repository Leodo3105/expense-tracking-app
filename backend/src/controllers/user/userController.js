import User from '../../models/user.js';

export const setSpendingLimit = async (req, res) => {
  const { spendingLimit } = req.body;

  try {
    // Tìm người dùng hiện tại
    const user = await User.findByPk(req.user.id);

    if (!user) {
      return res.status(404).json({ error: 'Người dùng không tồn tại!' });
    }

    // Cập nhật hạn mức chi tiêu
    user.spendingLimit = spendingLimit;
    await user.save();

    res.status(200).json({ message: 'Hạn mức chi tiêu đã được cập nhật!', spendingLimit: user.spendingLimit });
  } catch (error) {
    console.error('Error while setting spending limit:', error);
    res.status(500).json({ error: error.message });
  }
};
