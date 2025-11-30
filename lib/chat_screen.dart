import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Mesaj yazılan kutucuğu kontrol etmek için
  final TextEditingController _messageController = TextEditingController();

  // Firebase Veritabanı referansı. "comments" başlığı altına kaydedeceğiz.
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('comments');

  // Mesaj gönderme fonksiyonu
  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      // Veritabanına yeni bir veri ekle (push)
      _dbRef.push().set({
        'message': _messageController.text,
        'timestamp': DateTime.now().millisecondsSinceEpoch, // Sıralama için zaman
      });
      // Kutucuğu temizle
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Comment List"),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          // LİSTE KISMI
          Expanded(
            child: StreamBuilder(
              // Veritabanındaki değişiklikleri canlı dinle (Stream)
              stream: _dbRef.onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                // Veri yoksa veya yükleniyorsa
                if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                  return const Center(child: Text("No comments yet..."));
                }

                // Gelen veriyi işle (Parsing)
                // Firebase veriyi Map olarak verir: {"id1": {"message": "selam"}, "id2": ...}
                Map<dynamic, dynamic> map = snapshot.data!.snapshot.value as Map;
                List<dynamic> comments = [];

                map.forEach((key, value) {
                  comments.add(value);
                });

                // Mesajları zamana göre sırala (Eskiden yeniye)
                comments.sort((a, b) => (a['timestamp'] ?? 0).compareTo(b['timestamp'] ?? 0));

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Konuşma Balonu İkonu
                          const Icon(Icons.comment, color: Colors.black54, size: 24),
                          const SizedBox(width: 12),
                          // Mesaj Metni
                          Expanded(
                            child: Text(
                              comments[index]['message'],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // GİRİŞ ALANI (Input Field)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter a comment...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _sendMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200], // Buton rengi
                    foregroundColor: Colors.black, // Yazı rengi
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Send"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}