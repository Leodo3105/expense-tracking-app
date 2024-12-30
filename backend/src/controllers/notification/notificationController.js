import Notification from "../../models/notification.js";

export const addNotification = async (req, res) => {
    const { userId, type, message } = req.body;
  
    try {
      const notification = await Notification.create({
        userId,
        type,
        message,
      });
  
      res.status(201).json(notification);
    } catch (error) {
      console.error('Error while adding notification:', error);
      res.status(500).json({ error: error.message });
    }
};

export const getNotifications = async (req, res) => {
    try {
      const notifications = await Notification.findAll({
        where: { userId: req.user.id },
        order: [['createdAt', 'DESC']],
      });
  
      res.status(200).json(notifications);
    } catch (error) {
      console.error('Error while fetching notifications:', error);
      res.status(500).json({ error: error.message });
    }
};

export const getNotificationById = async (req, res) => {
  const { id } = req.params;

  try {
    // Tìm thông báo theo ID và userId
    const notification = await Notification.findOne({
      where: { id, userId: req.user.id },
    });

    if (!notification) {
      return res.status(404).json({ error: 'Thông báo không tồn tại' });
    }

    // Cập nhật trạng thái isRead thành true
    if (!notification.isRead) {
      notification.isRead = true;
      await notification.save(); // Lưu thay đổi vào cơ sở dữ liệu
    }

    res.status(200).json(notification);
  } catch (error) {
    console.error('Error while fetching notification details:', error);
    res.status(500).json({ error: error.message });
  }
};


  
  
  