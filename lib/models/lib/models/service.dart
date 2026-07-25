class Service {
      int? id;
        String serviceName;
          double amount;

            Service({
                this.id,
                    required this.serviceName,
                        required this.amount,
                          });

                            Map<String, dynamic> toMap() {
                                return {
                                      'id': id,
                                            'serviceName': serviceName,
                                                  'amount': amount,
                                                      };
                                                        }

                                                          factory Service.fromMap(Map<String, dynamic> map) {
                                                              return Service(
                                                                    id: map['id'],
                                                                          serviceName: map['serviceName'],
                                                                                amount: map['amount'],
                                                                                    );
                                                                                      }
                                                                                      }
}