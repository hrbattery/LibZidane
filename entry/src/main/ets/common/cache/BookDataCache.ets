import { FullBookData } from '../../model/entities/BookModel';
import { CacheManager } from './CacheManager';

export const bookDataCache = new CacheManager<FullBookData>("bookDataCache")