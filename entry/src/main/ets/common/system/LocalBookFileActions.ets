import { common, wantConstant } from '@kit.AbilityKit';
import { uniformTypeDescriptor } from '@kit.ArkData';
import { fileIo as fs, fileUri, picker } from '@kit.CoreFileKit';
import { LocalBookRecord, localBookFileName } from '../../model/entities/LocalBookRecord';
import { getLocalBookStore } from '../../model/storage/LocalBookStore';

/** Resolve a file type without limiting downloads to formats with an installed reader. */
function mimeType(extension: string): string {
  if (extension === 'epub') {
    return 'application/epub+zip';
  }
  if (extension === 'pdf') {
    return 'application/pdf';
  }
  try {
    const type = uniformTypeDescriptor.getUniformDataTypeByFilenameExtension(`.${extension}`);
    return uniformTypeDescriptor.getTypeDescriptor(type).mimeTypes[0] || 'application/octet-stream';
  } catch {
    return 'application/octet-stream';
  }
}

/** Ask the system to open an application-owned book with read-only access. */
export async function openLocalBook(context: common.UIAbilityContext, record: LocalBookRecord): Promise<void> {
  const store = getLocalBookStore(context);
  if (!store.isAvailable(record)) {
    throw new Error('Local file is unavailable');
  }
  await context.startAbility({
    action: 'ohos.want.action.viewData',
    uri: fileUri.getUriFromPath(store.filePath(record)),
    type: mimeType(record.extension),
    flags: wantConstant.Flags.FLAG_AUTH_READ_URI_PERMISSION
  });
}

/** Copy to the URI returned by the save picker; an empty selection is cancellation. */
export async function exportLocalBook(context: common.UIAbilityContext, record: LocalBookRecord): Promise<boolean> {
  const store = getLocalBookStore(context);
  if (!store.isAvailable(record)) {
    throw new Error('Local file is unavailable');
  }
  const options = new picker.DocumentSaveOptions();
  options.newFileNames = [localBookFileName(record.fileName, record.extension)];
  const uris = await new picker.DocumentViewPicker(context).save(options);
  if (uris.length === 0) {
    return false;
  }
  const destination = await fs.open(uris[0], fs.OpenMode.READ_WRITE | fs.OpenMode.TRUNC);
  try {
    await fs.copyFile(store.filePath(record), destination.fd);
  } finally {
    await fs.close(destination);
  }
  return true;
}
