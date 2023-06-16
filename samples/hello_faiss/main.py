import faiss
import numpy as np
import time

np.random.seed(123)
D = 128
N = 1000
X = np.random.random((N, D)).astype(np.float32)
M = 64
nbits = 4

pq = faiss.IndexPQ(D, M, nbits)
pq.train(X)
pq.add(X)

pq_fast = faiss.IndexPQFastScan(D, M, nbits)
pq_fast.train(X)
pq_fast.add(X)

t0 = time.time()
d1, ids1 = pq.search(x=X[:3], k=5)
t1 = time.time()
print(f"pq: {(t1 - t0) * 1000} msec")

t0 = time.time()
d2, ids2 = pq_fast.search(x=X[:3], k=5)
t1 = time.time()
print(f"pq_fast: {(t1 - t0) * 1000} msec")

assert np.allclose(ids1, ids2)