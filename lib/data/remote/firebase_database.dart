import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_database.g.dart';

@Riverpod(keepAlive: true)
FirebaseFirestore firebaseFirestore(ref) {
  return FirebaseFirestore.instance;
}

@Riverpod(keepAlive: true)
FirebaseDatabase firebaseDatabase(ref) {
  return FirebaseDatabase(instance: ref.watch(firebaseFirestoreProvider));
}

class FirebaseDatabase {
  FirebaseDatabase({required this.instance});
  final FirebaseFirestore instance;

  static void useEmulator({
    String emulatorHost = 'localhost',
    int emulatorPort = 8080,
  }) {
    FirebaseFirestore.instance.useFirestoreEmulator(
      emulatorHost,
      emulatorPort,
    );
  }

  StreamSubscription? _colStreamSub;
  StreamSubscription? _docStreamSub;

  Future<void> clearCachedData() async {
    await FirebaseFirestore.instance.clearPersistence();
  }

  void cancelStreams() {
    _colStreamSub?.cancel();
    _docStreamSub?.cancel();
  }

  Future<bool> docExists({
    required String path,
  }) async {
    final DocumentReference reference = FirebaseFirestore.instance.doc(path);
    return (await reference.get()).exists;
  }

  Future<T?> getData<T>({
    required String path,
    required T Function(Map<String, dynamic> data, String documentID) builder,
  }) async {
    final DocumentReference reference = FirebaseFirestore.instance.doc(path);
    final DocumentSnapshot snapshot = await reference.get();
    if (!snapshot.exists) return null;

    return builder(snapshot.data() as Map<String, dynamic>, snapshot.id);
  }

  Future<void> setData({
    required String path,
    required Map<String, dynamic> data,
    bool merge = true,
  }) async {
    final reference = FirebaseFirestore.instance.doc(path);
    await reference.set(data, SetOptions(merge: merge));
  }

  Future<void> setBatchData({
    required String baseColPath,
    String endPath = '',
    required Map<String, dynamic> Function(String) dataFromId,
    Query Function(Query query)? queryBuilder,
    bool merge = false,
  }) async {
    final List<String> docIdList = await collectionToList(
      path: baseColPath,
      builder: (_, docId) => docId,
      queryBuilder: queryBuilder,
    );

    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (final docId in docIdList) {
      final path = '$baseColPath/$docId/$endPath';
      final reference = FirebaseFirestore.instance.doc(path);
      batch.set(reference, dataFromId(docId), SetOptions(merge: merge));
    }

    return batch.commit();
  }

  Future<void> setBatchDataForDocInList({
    required String baseColPath,
    required List<String> docIdList,
    required Map<String, dynamic> Function(String) dataFromId,
    bool merge = true,
  }) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (final docId in docIdList) {
      final path = '$baseColPath/$docId';
      final reference = FirebaseFirestore.instance.doc(path);
      batch.set(reference, dataFromId(docId), SetOptions(merge: merge));
    }

    return batch.commit();
  }

  Future<void> deleteData({required String path}) async {
    final reference = FirebaseFirestore.instance.doc(path);
    await reference.delete();
  }

  Future<void> batchDelete({
    required String baseColPath,
    required String endPath,
    Query Function(Query query)? queryBuilder,
  }) async {
    final List<String> docIdList = await collectionToList(
      path: baseColPath,
      builder: (_, docId) => docId,
      queryBuilder: queryBuilder,
    );

    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (final docId in docIdList) {
      final path = '$baseColPath/$docId/$endPath';
      final reference = FirebaseFirestore.instance.doc(path);
      batch.delete(reference);
    }

    return batch.commit();
  }

  Future<void> moveData({
    required String sourcePath,
    required String destPath,
  }) async {
    final doc = await getData(
      path: sourcePath,
      builder: (data, _) => data,
    );
    await setData(
      path: destPath,
      data: doc!,
    );
    await deleteData(path: sourcePath);
  }

  Stream<List<T>> collectionStream<T>({
    required String path,
    required T Function(Map<String, dynamic> data, String documentID) builder,
    Query Function(Query query)? queryBuilder,
    int Function(T lhs, T rhs)? sort,
    bool isCollectionGroup = false,
  }) {
    final streamController = StreamController<List<T>>();
    final firestore = FirebaseFirestore.instance;
    Query query = isCollectionGroup
        ? firestore.collectionGroup(path)
        : firestore.collection(path);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    final Stream<QuerySnapshot> snapshots = query.snapshots();
    _colStreamSub = snapshots.listen(
      (snapshot) {
        final result = snapshot.docs
            .map((snapshot) =>
                builder(snapshot.data() as Map<String, dynamic>, snapshot.id))
            .where((value) => value != null)
            .toList();
        if (sort != null) {
          result.sort(sort);
        }
        if (!streamController.isClosed) {
          streamController.add(result);
        }
      },
      onError: (error) {
        if (error is FirebaseException && error.code == "permission-denied") {
          // Do nothing, this exception is expected behavior due to
          // rules laid out in firestore.rules
          return;
        }
      },
      cancelOnError: true,
    );
    streamController.onCancel = streamController.close;

    return streamController.stream;
  }

  Stream<T?> documentStream<T>({
    required String path,
    required T Function(Map<String, dynamic> data, String documentID) builder,
  }) {
    final streamController = StreamController<T?>();
    final DocumentReference reference = FirebaseFirestore.instance.doc(path);
    final Stream<DocumentSnapshot> snapshots = reference.snapshots();
    _docStreamSub = snapshots.listen(
      (snapshot) {
        final data = snapshot.data();
        if (streamController.isClosed) return;
        if (data != null) {
          streamController.add(builder(
            snapshot.data() as Map<String, dynamic>,
            snapshot.id,
          ));
        } else {
          streamController.add(null);
        }
      },
      onError: (error) {
        if (error is FirebaseException && error.code == "permission-denied") {
          // Do nothing, this exception is expected behavior due to
          // rules laid out in firestore.rules
          return;
        }
      },
      cancelOnError: true,
    );
    streamController.onCancel = streamController.close;

    return streamController.stream;
  }

  Future<List<T>> collectionToList<T>({
    required String path,
    required T Function(Map<String, dynamic> data, String documentID) builder,
    Query Function(Query query)? queryBuilder,
    int Function(T lhs, T rhs)? sort,
  }) async {
    Query query = FirebaseFirestore.instance.collection(path);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    final QuerySnapshot snapshots = await query.get();

    final result = snapshots.docs
        .map((snapshot) =>
            builder(snapshot.data() as Map<String, dynamic>, snapshot.id))
        .where((value) => value != null)
        .toList();
    if (sort != null) {
      result.sort(sort);
    }

    return result;
  }
}
