import faiss

index_flat = faiss.IndexFlatL2(16)
gpu_index_flat = faiss.index_cpu_to_gpu(faiss.StandardGpuResources(), 0, index_flat)
