

## mutex
try acquire使用不等待的rtt mutex，rtt mutex和libmetal的返回值不同。
rtt
```
RT_EOK  成功获得互斥量
-RT_ETIMEOUT    超时
-RT_ERROR   获取失败
```

```
/\*\*
 * @brief       Try to acquire a mutex
 * @param[in]   mutex   Mutex to mutex.
 * @return      0 on failure to acquire, non-zero on success.
 \*/
static inline int metal_mutex_try_acquire(metal_mutex_t \*mutex)
```

为了体现大于0的值是成功，把rtt的err取了相反数。

