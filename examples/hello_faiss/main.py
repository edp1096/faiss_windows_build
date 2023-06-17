import faiss
import numpy as np


""" Save index """
items = np.array([
    [1.2, 3.4, 5.6],
    [2.1, 4.3, 6.5],
    [0.8, 1.5, 2.7],
    [3.2, 2.8, 1.4],
], dtype=np.float32)

# dimension = 3
dimension = items[0].shape[0]
index = faiss.IndexFlatL2(dimension)
index.add(items)

faiss.write_index(index, "index_euc.fss") # save index
del index # unload index


""" Load index """
index = faiss.read_index("index_euc.fss") # load index

query = np.array([0.9, 2.3, 4.5], dtype=np.float32)

n_neighbors = 2 # k
dists_array, idxes_array = index.search(query.reshape(1, -1), n_neighbors)
idxes, dists = idxes_array[0], dists_array[0]

for idx, dist in zip(idxes, dists):
    print(f"idx: {idx}, item: {items[idx]}, dist: {dist}")


""" Get distance between 1st and 2nd """
index2 = faiss.IndexFlatL2(dimension)
index2.add(items[0].reshape(1, -1))

dists, _ = index2.search(items[2].reshape(1, -1), 1)
print(f"distance between items[0] and items[2]: {dists[0][0]}")
