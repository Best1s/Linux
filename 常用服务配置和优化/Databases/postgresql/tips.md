postgresql:  手动触发归档  select pg_switch_xlog();

```
archive_mode = on
archive_command = 'test ! -f /archive/archive_active || cp %p /data/archive/%f'
```

