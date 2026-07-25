class Customer {
      int? id;
        String name;
          String phone;
            String email;
              String address;

                Customer({
                    this.id,
                        required this.name,
                            required this.phone,
                                required this.email,
                                    required this.address,
                                      });

                                        Map<String, dynamic> toMap() {
                                            return {
                                                  'id': id,
                                                        'name': name,
                                                              'phone': phone,
                                                                    'email': email,
                                                                          'address': address,
                                                                              };
                                                                                }

                                                                                  factory Customer.fromMap(Map<String, dynamic> map) {
                                                                                      return Customer(
                                                                                            id: map['id'],
                                                                                                  name: map['name'],
                                                                                                        phone: map['phone'],
                                                                                                              email: map['email'],
                                                                                                                    address: map['address'],
                                                                                                                        );
                                                                                                                          }
                                                                                                                          }
}