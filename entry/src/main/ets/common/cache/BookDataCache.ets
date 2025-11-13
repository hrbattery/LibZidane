import { FullBookDataType } from "../../model/entities/BookModel";
import { CacheManager } from "./CacheManager";

export const bookDataCache = new CacheManager<FullBookDataType>("bookDataCache")