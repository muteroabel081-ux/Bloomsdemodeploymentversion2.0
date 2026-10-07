import { NextRequest, NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabase';

export async function POST(request: NextRequest) {
  try {
    const formData = await request.formData();
    const file = formData.get('file') as File | null;

    if (!file) {
      return NextResponse.json({ error: 'No file uploaded' }, { status: 400 });
    }

    const bytes = await file.arrayBuffer();
    const buffer = Buffer.from(bytes);

    // Clean filename and create unique timestamped name
    const ext = file.name.split('.').pop()?.toLowerCase() || 'png';
    const safeName = file.name
      .replace(/[^a-zA-Z0-9.-]/g, '_')
      .replace(/\.[^/.]+$/, '');
    const filename = `${safeName}-${Date.now()}.${ext}`;

    // Upload directly to Supabase Storage 'media' bucket
    const { data, error } = await supabaseAdmin.storage
      .from('media')
      .upload(filename, buffer, {
        contentType: file.type || 'application/octet-stream',
        upsert: true,
      });

    if (error) {
      console.error('Supabase upload error:', error);
      return NextResponse.json(
        { error: `Supabase upload failed: ${error.message}` },
        { status: 500 }
      );
    }

    // Get permanent public CDN URL
    const { data: urlData } = supabaseAdmin.storage
      .from('media')
      .getPublicUrl(filename);

    const publicUrl = urlData.publicUrl;

    return NextResponse.json({
      url: publicUrl,
      filename,
      size: file.size,
      type: file.type,
      success: true,
    });
  } catch (error) {
    console.error('File upload error:', error);
    return NextResponse.json(
      { error: 'Failed to upload file' },
      { status: 500 }
    );
  }
}

export async function DELETE(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const filename = searchParams.get('filename');

    if (!filename) {
      return NextResponse.json(
        { error: 'Filename parameter is required' },
        { status: 400 }
      );
    }

    const { data, error } = await supabaseAdmin.storage
      .from('media')
      .remove([filename]);

    if (error) {
      console.error('Supabase delete error:', error);
      return NextResponse.json(
        { error: `Failed to delete file: ${error.message}` },
        { status: 500 }
      );
    }

    return NextResponse.json({ success: true, removed: data });
  } catch (error) {
    console.error('File delete error:', error);
    return NextResponse.json(
      { error: 'Failed to delete file' },
      { status: 500 }
    );
  }
}
