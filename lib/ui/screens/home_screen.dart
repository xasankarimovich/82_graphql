import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../core/constants/graphql_mutations.dart';
import '../../core/constants/prahql_queries.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _addProduct(BuildContext context) async {
    final client = GraphQLProvider.of(context).value;

    try {
      final result = await client.mutate(
        MutationOptions(
          document: gql(addProduct),
          variables: const {
            'title': "Salom test",
            'price': 10.0,
            'description': "test desc",
            'categoryId': 1,
            'images': [
              "https://avatars.mds.yandex.net/i?id=1e433a61e14ac53896ba9dd8fb60c3f1997bdf6d6e29ffc1-10534377-images-thumbs&n=13"
            ],
          },
        ),
      );

      if (result.hasException) {
        throw result.exception!;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ma'lumotlar muvaffaqiyatli qo'shildi"),
        ),
      );
      print(result);
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
        ),
      );
    }
  }

  Future<void> _editProduct(BuildContext context, String productId) async {
    final client = GraphQLProvider.of(context).value;

    try {
      final result = await client.mutate(
        MutationOptions(
          document: gql(updateProduct),
          variables: {
            'id': productId,
            'title': "O'zgargan malumot",
            'price': 123.0,
            'description': "test desc",
            'categoryId': 1,
          },
        ),
      );

      if (result.hasException) {
        throw result.exception!;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ma'lumotlar muvaffaqiyatli yangilandi"),
        ),
      );
      print(result);
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
        ),
      );
    }
  }

  Future<void> _deleteProduct(BuildContext context, String productId) async {
    final client = GraphQLProvider.of(context).value;

    try {
      final result = await client.mutate(
        MutationOptions(
          document: gql(deleteProduct),
          variables: {
            'id': productId,
          },
        ),
      );

      if (result.hasException) {
        throw result.exception!;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ma'lumotlar muvaffaqiyatli o'chirildi"),
        ),
      );
      print(result);
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Screen"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Query(
          options: QueryOptions(
            document: gql(fetchProducts),
          ),
          builder: (QueryResult result,
              {FetchMore? fetchMore, VoidCallback? refetch}) {
            if (result.hasException) {
              return Center(
                child: Text(result.exception.toString()),
              );
            }

            if (result.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            List products = result.data!['products'];
            if (products.isEmpty) {
              return const Center(
                child: Text("No products found"),
              );
            }

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final imageUrl = (product['images'] != null && product['images'].isNotEmpty)
                    ? product['images'][0]
                    : "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQT5aCMO24e6ZTz7_TTUdoqiclVyuhAzV0kFw&s";

                return Card(
                  elevation: 7,
                  color: Colors.teal.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,

                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product['description'],
                          style: const TextStyle(fontSize: 14),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {
                                _editProduct(context, product['id']);
                              },
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.black,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                _deleteProduct(context, product['id']);
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addProduct(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
